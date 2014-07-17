#!/usr/bin/perl -w

#
# Simple test of fanotify_init and fanotify_mark system calls.
# Please note that the functional interface used here is NOT recommended.
#
# See 03-read-some-events.t for an OO interface test.
#
use strict;

use Test::More;

use Linux::Fanotify qw(:consts :funcs);
use Fcntl;	# Provides O_* constants required for fanotify_init
use File::Basename;
use Cwd qw(abs_path);

if ($< != 0) {
	plan skip_all => 'no root';
}

plan tests => 3;

my $fanogroup = fanotify_init(FAN_CLOEXEC | FAN_CLASS_CONTENT | FAN_NONBLOCK, O_RDONLY | O_LARGEFILE);

ok($fanogroup, "Have a fanotify group");

my $validgrp = $fanogroup && UNIVERSAL::isa($fanogroup, 'Linux::Fanotify::FanotifyGroup');
ok($validgrp, "Our group is a Linux::Fanotify::FanotifyGroup");

SKIP: {
	skip 'Cannot continue without a valid group', 1 unless ($validgrp);

	my $path = abs_path(dirname(__FILE__)) . '/testdir/';
	mkdir($path);
	# diag("path is $path\n");
	my $ret = fanotify_mark($fanogroup, FAN_MARK_ADD, FAN_ACCESS, -1, $path);

	ok($ret, 'Successfully marked ' . $path);
	if (!$ret) {
		diag("After failed fanotify_mark, errno is $!\n");
	}
}

1;
