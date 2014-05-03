package Cpanel::Easy::PHP5::PhalconPHP;

# cpanel - Cpanel/Easy/PHP5/PhalconPHP.pm                
# Parts of this code are subject to the cPanel license. Unauthorized copying is prohibited

# Custom module provided by ThecPanelAdmin / TCA Server Solutions, LLC
# Vanessa Vasile - http://thecpaneladmin.com

use Cpanel::Version::Compare ();

our $easyconfig = {
    'name'      => 'Phalcon',
    'note'      => q{You may need to install the following PHP extensions: mbstring, mcrypt, openssl, PDO, PDO Sqlite, PDO MySQL.},
    'verify_on' => q{This option will enable PDO, but you may need to select PDO MySQL and/or PDO SQLite if your application(s) require this functionality.},

    # Require PDO at least. The user can enable PDO::MySQL and/or PDO::SQLite if needed.
    'depends' => { 'optmods' => { 'Cpanel::Easy::PHP5::PDO' => 1, }, },
    'implies'       => { 'Cpanel::Easy::PHP5::PDO' => 1, },
    'url'           => 'http://phalconphp.com/',
    'when_i_am_off' => sub {
        my $self = shift;
        if ( !$self->get_param('makecpphp') ) {
            if ( -e '/usr/local/lib/php.ini' ) {
                Cpanel::FileUtils::regex_rep_file( '/usr/local/lib/php.ini', { qr{^\s*extension\s*=\s*"?phalcon\.so"?\s*$}is => q{} }, {}, );
            }
        }
    },
    'step' => {
        '0' => {
            'name'    => 'Download PhalconPHP',
            'command' => sub {
                my ($self) = @_;
                return $self->run_system_cmd_returnable( [ 'wget', '-O', $self->{'opt_mod_src_dir'}.'/cphalcon.zip', 'https://github.com/phalcon/cphalcon/archive/master.zip'] );
            },
        },
        '1' => {
            'name'    => 'Extract source',
            'command' => sub {
                my ($self) = @_;
                my $phalcon_src = $self->{'opt_mod_src_dir'}.'/cphalcon-master/ext/';
                my $start = $self->cwd();

                chdir $self->{'opt_mod_src_dir'} or return ( 0, q{Could not chdir into [_1]: [_2]}, $self->{'opt_mod_src_dir'}, $! );
                @return = $self->run_system_cmd_returnable( ['unzip', 'cphalcon.zip'] );

            },
        },
        '2' => {
            'name'    => 'phpize',
            'command' => sub {
                my ($self) = @_;
                my $phalcon_src = $self->{'opt_mod_src_dir'}.'/cphalcon-master/ext/';

                chdir $phalcon_src or return ( 0, q{Could not chdir into [_1]: [_2]}, $phalcon_src, $! );
                @return = $self->run_system_cmd_returnable( ['/usr/local/bin/phpize'] );

            },
        },
       '3' => {
            'name'    => 'configure',
            'command' => sub {
                my ($self) = @_;

                return $self->run_system_cmd_returnable( [ './configure', '--with-php-config=/usr/local/bin/php-config' ] ); # EA defaults to /usr for some reason
            },
        },
       '4' => {
            'name'    => 'make',
            'command' => sub {
                my ($self) = @_;

                return $self->run_system_cmd_returnable( [ 'make' ] );
            },
        },
       '5' => {
            'name'    => 'make install',
            'command' => sub {
                my ($self) = @_;
                my $start = $self->cwd();

                my $phalcon_src = $self->{'opt_mod_src_dir'}.'/cphalcon-master/ext/';
                chdir $phalcon_src or return ( 0, q{Could not chdir into [_1]: [_2]}, $phalcon_src, $! );
                return $self->run_system_cmd_returnable( [ 'make install' ] );
                chdir $start or return ( 0, q{Could not chdir back into [_1]: [_2]}, $start, $! );
            }, 
        },
       '6' => {
            'name'    => 'Add to php.ini',
            'command' => sub {
                my ($self) = @_;
                my $command = sub {
                    my ($self) = @_;

                    # add extension=phalcon.so

                    my $append = '';
                    $self->set_phpini_object_key_from('/usr/local/lib/php.ini');

                  EXT:
                    for my $new (qw(phalcon.so)) {
                        next EXT if grep / \A \Q$new\E \z /xms, @{ $self->{'_'}{'php_ini'}{'extension'} };
                        $append .= "extension=$new\n";
                    }

                    if ($append) {
                        if ( open my $ini_fh, '>>', '/usr/local/lib/php.ini' ) {
                            print {$ini_fh} $append;
                            close $ini_fh;
                        }
                        else {
                            $self->print_alert( q{Could not append '[_1]' with '[_2]': [_3]}, '/usr/local/lib/php.ini', $append, $! );
                        }
                    }

                    return ( 1, 'ok' );
                };

                my ( $v, $spec ) = $self->get_php_version();
                return $self->add_to_modify_later_queue(
                    'Cpanel::Easy::PHP5::' . $spec,
                    {
                        'step' => {
                            '15.41' => {
                                'name'    => 'PhalconPHP to php.ini',
                                'command' => $command,
                            },
                        }
                    },
                );
            },
        },
    },
};

1;
