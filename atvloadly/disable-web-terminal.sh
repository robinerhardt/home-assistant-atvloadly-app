#!/bin/sh
# Upstream exposes /ws/tty without an authentication middleware. The Home
# Assistant wrapper intentionally prevents that endpoint from spawning a shell.
printf '%s\n' 'The atvloadly web terminal is disabled in this Home Assistant app.' >&2
exit 126
