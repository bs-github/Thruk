package Thruk;

use 5.008000;
use strict;
use warnings;

use Catalyst::Runtime '5.70';
use Thruk::Helper;

###################################################
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages

use parent qw/Catalyst/;
use Catalyst qw/
                Authentication
                Authorization::ThrukRoles
                CustomErrorMessage
                ConfigLoader
                StackTrace
                Static::Simple
                Redirect
                Compress::Gzip
                /;
our $VERSION = '0.20_2';

###################################################
# Configure the application.
#
# Note that settings in thruk.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config('name'                   => 'Thruk',
                    'version'                => $VERSION,
                    'released'               => 'January 10, 2010',
                    'View::TT'               => {
                        TEMPLATE_EXTENSION => '.tt',
                        ENCODING           => 'utf8',
                        INCLUDE_PATH       =>  'templates',
                        FILTERS            => {
                                                'duration'  => \&Thruk::Helper::filter_duration,
                                            },
                        PRE_DEFINE         => {
                                                'sprintf'   => sub { my $format = shift; sprintf $format, @_ },
                                                'duration'  => \&Thruk::Helper::filter_duration,
                                            },
                        PRE_CHOMP          => 1,
                        POST_CHOMP         => 1,
                        STRICT             => 0,
#                        DEBUG              => 'all',
                    },
                    'Plugin::ConfigLoader'   => { file => 'thruk.conf' },
                    'Plugin::Authentication' => {
                        default_realm => 'Thruk',
                        realms => {
                            Thruk => { credential => { class => 'Thruk'       },
                                       store      => { class => 'FromCGIConf' },
                            }
                        }
                    },
                    'custom-error-message' => {
                        'error-template'    => 'error.tt',
                        'response-status'   => 500,
                    },
                    'static' => {
                        'ignore_extensions' => [ qw/tpl tt tt2/ ],
                    },
);

###################################################
# Start the application
__PACKAGE__->setup();


###################################################
# Logging
#
# check if logdir exists
if(!-d 'logs') { mkdir('logs') or die("failed to create logs directory: $!"); }

# initialize Log4Perl
use Catalyst::Log::Log4perl;

my $log4perlconfig;
my $log4confarr = __PACKAGE__->config->{'Catalyst::Log::Log4perl'}->{'conf'};
if(defined $log4confarr and ref $log4confarr eq 'ARRAY') {
    $log4perlconfig .= join("\n", @{$log4confarr})."\n";
    __PACKAGE__->log(Catalyst::Log::Log4perl->new(\$log4perlconfig));
}
elsif(!__PACKAGE__->debug) {
    __PACKAGE__->log->levels( 'info', 'warn', 'error', 'fatal' );
}

###################################################


=head1 NAME

Thruk - Catalyst based monitoring web interface

=head1 SYNOPSIS

    script/thruk_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Thruk::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Sven Nierlein, 2009, <nierlein@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;