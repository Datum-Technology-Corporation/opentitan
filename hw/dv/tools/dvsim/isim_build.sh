#!/usr/bin/env bash
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Build step for the iSim tool configuration (isim.hjson).
#
#   isim_build.sh <build_dir> <isim argument>...
#
# FuseSoC's file list (the `-f <sv_flist>` among the arguments) carries the
# DPI C sources (cryptoc_dpi, ...) beside the SystemVerilog.  iSim analyses
# SystemVerilog only, so this script splits the list:
#
#   * every .c / .cc / .cpp entry is compiled into ONE shared object,
#     <build_dir>/isim_dpi.so, which the run step loads with +sv_lib=;
#   * the rest becomes <build_dir>/isim_sv.f, handed to `isim -c`.
#
# Run from the file list's own directory (sim.mk does: `cd {sv_flist_gen_dir}`),
# so relative entries resolve exactly as FuseSoC wrote them.
set -euo pipefail

build_dir="$1"; shift
args=()
flist=""
while [ $# -gt 0 ]; do
  if [ "$1" = "-f" ] && [ $# -ge 2 ]; then
    flist="$2"; shift 2
    continue
  fi
  args+=("$1"); shift
done
[ -n "$flist" ] || { echo "isim_build.sh: no -f <file list> among the arguments" >&2; exit 2; }

isim_bin="$(command -v isim)" || { echo "isim_build.sh: isim is not on PATH" >&2; exit 2; }
isim_inc="$(cd "$(dirname "$isim_bin")/../include" && pwd)"

sv_f="$build_dir/isim_sv.f"
c_srcs=()
c_incs=("-I$isim_inc" "-I$build_dir/src/lowrisc_dv_secded_enc_0")
: > "$sv_f"
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    *.c|*.cc|*.cpp)
      c_srcs+=("$line")
      c_incs+=("-I$(dirname "$line")")
      ;;
    *)
      printf '%s\n' "$line" >> "$sv_f"
      ;;
  esac
done < "$flist"

if [ ${#c_srcs[@]} -gt 0 ]; then
  cc="${CC:-cc}"
  echo "isim_build.sh: compiling ${#c_srcs[@]} DPI C source(s) into $build_dir/isim_dpi.so"
  "$cc" -shared -fPIC -O2 "${c_incs[@]}" -o "$build_dir/isim_dpi.so" "${c_srcs[@]}"
else
  # An empty library keeps the run step's +sv_lib= unconditional.
  "${CC:-cc}" -shared -fPIC -o "$build_dir/isim_dpi.so" -x c /dev/null
fi

exec isim "${args[@]}" -f "$sv_f"
