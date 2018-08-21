#
# Copyright 2018 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package cloud::azure::storage::mode::listresources;

use base qw(centreon::plugins::mode);

use strict;
use warnings;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;
    
    $self->{version} = '1.0';
    $options{options}->add_options(arguments =>
                                {
                                    "resource-group:s"    => { name => 'resource_group' },
                                    "resource-type:s"     => { name => 'resource_type', default => 'storageAccounts' },
                                    "location:s"          => { name => 'location' },
                                    "filter-name:s"       => { name => 'filter_name' },
                                });

    return $self;
}

sub check_options {
    my ($self, %options) = @_;
    $self->SUPER::init(%options);
}

sub manage_selection {
    my ($self, %options) = @_;

    $self->{resources} = $options{custom}->azure_list_resources(
        namespace => 'Microsoft.Storage',
        resource_type => $self->{option_results}->{resource_type},
        location => $self->{option_results}->{location},
        resource_group => $self->{option_results}->{resource_group}
    );
}

sub run {
    my ($self, %options) = @_;

    $self->manage_selection(%options);
    foreach my $resource (@{$self->{resources}}) {
        next if (defined($self->{option_results}->{filter_name}) && $self->{option_results}->{filter_name} ne ''
            && $resource->{name} !~ /$self->{option_results}->{filter_name}/);
        $resource->{type} =~ s/Microsoft.Storage\///g;
        $self->{output}->output_add(long_msg => sprintf("[name = %s][resourcegroup = %s][location = %s][id = %s][type = %s]",
            $resource->{name}, $resource->{resourceGroup}, $resource->{location}, $resource->{id}, $resource->{type}));
    }
    
    $self->{output}->output_add(severity => 'OK',
                                short_msg => 'List resources:');
    $self->{output}->display(nolabel => 1, force_ignore_perfdata => 1, force_long_output => 1);
    $self->{output}->exit();
}

sub disco_format {
    my ($self, %options) = @_;
    
    $self->{output}->add_disco_format(elements => ['name', 'resourcegroup', 'location', 'id', 'type']);
}

sub disco_show {
    my ($self, %options) = @_;

    $self->manage_selection(%options);
    foreach my $resource (@{$self->{resources}}) {
        $resource->{type} =~ s/Microsoft.Storage\///g;
        $self->{output}->add_disco_entry(
            name => $resource->{name},
            resourcegroup => $resource->{resourceGroup},
            location => $resource->{location},
            id => $resource->{id},
            type => $resource->{type},
        );
    }
}

1;

__END__

=head1 MODE

List storage resources.

=over 8

=item B<--resource-group>

Set resource group.

=item B<--resource-type>

Set resource type (Default: 'storageAccounts').

=item B<--location>

Set resource location.

=item B<--filter-name>

Filter resource name (Can be a regexp).

=back

=cut
