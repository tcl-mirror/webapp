#! /usr/bin/env tclsh

package require tcltest

lappend auto_path [file join [file dirname [info script]] ..]

namespace eval ::db {}
namespace eval ::config {}

if {[llength $argv] < 1} {
	puts stderr "Usage: test.tcl <driver>"
	puts stderr "Where driver is one of:"
	puts stderr "    mysql"
	puts stderr "    mk4"
	puts stderr "    sqlite"

	exit 1
}

set ::db::mode [lindex $argv 0]
set argv [lrange $argv 1 end]

switch -- $::db::mode {
	"mysql" {
		error "Not implemented"
	}
	"mk4" {
		set ::config::db(filename) "test.mk4"

		file delete -force -- test.mk4
	}
	"sqlite" {
		set ::config::db(filename) "test.sqlite"

		file delete -force -- test.sqlite
	}
}

package require db
package require debug

debug::logfile "-"

db::create -dbname test -fields [list joe:pk bob:u sally]

::tcltest::test db-0.0 "Empty db" -body {
	return [db::get -dbname test -field sally -where "joe=33"]
} -result ""

::tcltest::test db-0.1 "Unset" -body {
	db::set -dbname test -field joe 33 -field sally "Little Lamb"
	db::unset -dbname test -where "joe=33"
	return [db::get -dbname test -field sally -where "joe=33"]
} -result ""

::tcltest::test db-0.2 "Unset a single field" -body {
	db::set -dbname test -field joe 32 -field sally 2
	db::unset -dbname test -fields [list sally] -where "joe=32"
	return [db::get -dbname test -field sally -where "joe=32"]
} -cleanup {
	db::unset -dbname test -where "joe=32"
} -result ""

::tcltest::test db-1.0 "???" -body {
} -cleanup {
} -result ""

::tcltest::test db-1.1 "Simple set" -body {
	db::set -dbname test -field joe 33 -field sally "Little Lamb"
	return [db::get -dbname test -field sally -where "joe=33"]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result "Little Lamb"

::tcltest::test db-1.2 "Replacement set" -body {
	db::set -dbname test -field joe 33 -field sally "Little Lamb"
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -dbname test -field sally -where "joe=33"]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result "White as Snow"

::tcltest::test db-1.3 "Return multiple fields" -body {
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -dbname test -fields [list sally] -where "joe=33"]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result [list "White as Snow"]

::tcltest::test db-1.4 "Return multiple rows" -body {
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -dbname test -field sally]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result [list "White as Snow"]

::tcltest::test db-1.5 "Return multiple fields and multiple rows" -body {
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -dbname test -fields [list sally]]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result [list [list "White as Snow"]]

::tcltest::test db-1.6 "Return multiple fields (really) and multiple rows" -body {
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -dbname test -fields [list joe sally]]
} -cleanup {
	db::unset -dbname test -where "joe=33"
} -result [list [list "33" "White as Snow"]]

::tcltest::test db-2.0 "Implicit replacement" -body {
	db::set -dbname test -field joe 32 -field sally 1
	db::set -dbname test -field joe 32 -field sally 2
	return [db::get -dbname test -field sally -where "joe=32"]
} -cleanup {
	db::unset -dbname test -where "joe=32"
} -result "2"

::tcltest::test db-3.0 "Return entire DB" -body {
	db::set -dbname test -field joe 32 -field sally 2
	db::set -dbname test -field joe 33 -field sally "White as Snow"
	return [db::get -all -dbname test -fields [list joe sally]]
} -cleanup {
	db::unset -dbname test -where "joe=32"
	db::unset -dbname test -where "joe=33"
} -result [list [list 32 2] [list 33 "White as Snow"]]

::tcltest::test db-4.0 "Return fields" -body {
	return [db::fields -dbname test]
} -result [list joe bob sally]

::tcltest::test db-4.1 "Return fields with types" -body {
	return [db::fields -types -dbname test]
} -result [list joe:pk bob:u sally]

file delete -force -- test.mk4 test.sqlite
