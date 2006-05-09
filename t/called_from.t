#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Safe::Caller;

my $safe = Safe::Caller->new;
my $self = Foo->new($safe);
my @retval = $self->foo;
is($retval[0], 'main', '$self->{pkg}->()');
is($retval[1], 't/called_from.t', '$self->{file}->()');
is($retval[2], '12', '$self->{line}->()');
is($retval[3], 'Foo::foo', '$self->{sub}->()');
$self = Bar->new($safe);
@retval = $self->foo;
is($retval[0], 1, 'called_from_pkg()');
is($retval[1], 1, 'called_from_file()');
is($retval[2], 1, 'called_from_line()');
is($retval[3], 1, 'called_from_sub()');

package Foo;

sub new {
    my ($self, $safe) = @_;
    my $class = ref($self) || $self;
    return bless { safe => $safe }, $class;
}

sub foo { 
    my ($self) = @_;
    $self->bar; 
}

sub bar {
    my ($self) = @_;
    return map { $self->{safe}->{$_}->() } qw(pkg file line sub);
}

package Bar;

sub new {
    my ($self, $safe) = @_;
    my $class = ref($self) || $self;
    return bless { safe => $safe }, $class;
}

sub foo {
    my ($self) = @_;
    $self->bar;
}

sub bar {
    my ($self) = @_;
    return ($self->{safe}->called_from_pkg('Bar'), $self->{safe}->called_from_file('t/called_from.t'), 
            $self->{safe}->called_from_line(52),   $self->{safe}->called_from_sub('Bar::bar'));
}
