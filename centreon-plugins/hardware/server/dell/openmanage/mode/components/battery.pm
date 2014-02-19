################################################################################
# Copyright 2005-2013 MERETHIS
# Centreon is developped by : Julien Mathis and Romain Le Merlus under
# GPL Licence 2.0.
# 
# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation ; either version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with 
# this program; if not, see <http://www.gnu.org/licenses>.
# 
# Linking this program statically or dynamically with other modules is making a 
# combined work based on this program. Thus, the terms and conditions of the GNU 
# General Public License cover the whole combination.
# 
# As a special exception, the copyright holders of this program give MERETHIS 
# permission to link this program with independent modules to produce an executable, 
# regardless of the license terms of these independent modules, and to copy and 
# distribute the resulting executable under terms of MERETHIS choice, provided that 
# MERETHIS also meet, for each linked independent module, the terms  and conditions 
# of the license of that module. An independent module is a module which is not 
# derived from this program. If you modify this program, you may extend this 
# exception to your version of the program, but you are not obliged to do so. If you
# do not wish to do so, delete this exception statement from your version.
# 
# For more information : contact@centreon.com
# Authors : Quentin Garnier <qgarnier@merethis.com>
#
####################################################################################

package hardware::server::dell::openmanage::mode::components::battery;

use strict;
use warnings;

my %status = (
    1 => ['other', 'CRITICAL'], 
    2 => ['unknown', 'UNKNOWN'], 
    3 => ['ok', 'OK'], 
    4 => ['nonCritical', 'WARNING'],
    5 => ['critical', 'CRITICAL'],
    6 => ['nonRecoverable', 'CRITICAL'],
);

my %reading = (
    1 => 'Predictive Failure',
    2 => 'Failed',
    4 => 'Presence Detected',
);

sub check {
    my ($self) = @_;

    # In MIB '10892.mib'
    $self->{output}->output_add(long_msg => "Checking batteries");
    $self->{components}->{battery} = {name => 'batteries', total => 0};
    return if ($self->check_exclude('battery'));
   
    my $oid_batteryStatus = '.1.3.6.1.4.1.674.10892.1.600.50.1.5';
    my $oid_batteryReading = '.1.3.6.1.4.1.674.10892.1.600.50.1.6';
    my $oid_batteryLocationName = '.1.3.6.1.4.1.674.10892.1.600.50.1.7';

    my $result = $self->{snmp}->get_table(oid => $oid_batteryStatus);
    return if (scalar(keys %$result) <= 0);

    $self->{snmp}->load(oids => [$oid_batteryReading, $oid_batteryLocationName],
                        instances => [keys %$result],
                        instance_regexp => '(\d+\.\d+)$');
    my $result2 = $self->{snmp}->get_leef();
    return if (scalar(keys %$result2) <= 0);

    foreach my $key ($self->{snmp}->oid_lex_sort(keys %$result)) {
        $key =~ /(\d+)\.(\d+)$/;
        my ($chassis_Index, $battery_Index) = ($1, $2);
        my $instance = $chassis_Index . '.' . $battery_Index;
        
        my $battery_status = $result->{$key};
        my $battery_reading = $result2->{$oid_batteryReading . '.' . $instance};
        my $battery_locationName = $result2->{$oid_batteryLocationName . '.' . $instance};
       
        $self->{components}->{battery}->{total}++;
        $self->{output}->output_add(long_msg => sprintf("battery %d status is %s, reading is %s [location: %s].",
                                    $battery_Index, ${$status{$battery_status}}[0], $reading{$battery_reading},
                                    $battery_locationName
                                    ));

        if ($battery_status != 3) {
            $self->{output}->output_add(severity =>  ${$status{$battery_status}}[1],
                                        short_msg => sprintf("battery %d status is %s",
                                           $battery_Index, ${$status{$battery_status}}[0]));
        }

    }
}

1;
