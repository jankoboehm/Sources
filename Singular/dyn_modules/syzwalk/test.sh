#!/bin/sh

"$SINGULAR_EXECUTABLE" -teq "$srcdir/syzwalk.tst" || exit 1
