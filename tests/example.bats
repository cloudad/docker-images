#!/usr/bin/env bats

@test "example test" {
    run /bin/true
    [ "${status}" -eq 0 ]
}
