# Class: compellent
#
# This module manages compellent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class compellent {
  compellent::server { 'Test_Server':
    operatingsystem => 'Windows 2012',
    ensure          => 'present',
    serverfolder    => '',
    notes           => '',
    wwn             => '21000024FF44486F',
  }
}

