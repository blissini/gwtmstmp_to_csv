#!/usr/bin/env bash

#===============================================================================
#
# FILE: gwtmstp_to_csv.sh
#
# NAME: GW Timestamp to CSV utility
#
# DESCRIPTION: Utility to convert gw timestamp utility output to CSV
#
# CREATED: 16 Sep 2015
#
# AUTHOR: Philipp Metzler <pm@chili-it.de>
#
#===============================================================================

set -o nounset # Treat unset variables as an error

# config
# adjust ( 0 = off , 1 = on)
backup_time=0
restore_time=0
digest_time=0
modify_time=1

gwtmstmp_bin="/opt/novell/groupwise/agents/bin/gwtmstmp"
po="<path/to/PO>"
output_file=$HOME/$(date +%Y%m%d)_gwtmstmp_csv_export.csv


declare -a timestamp_array
timestamp_index+=(1)
if [ $backup_time == 1 ]; then
  timestamp_index+=(2)
fi
if [ $restore_time == 1 ]; then
  timestamp_index+=(3)
fi
if [ $digest_time == 1 ]; then
  timestamp_index+=(4)
fi
if [ $modify_time == 1 ]; then
  timestamp_index+=(5)
fi

declare -a timestamp_array
timestamp_array+=('User')
timestamp_array+=('Backup Time')
timestamp_array+=('Restore Time')
timestamp_array+=('Digest Retention Time')
timestamp_array+=('Modified Retention Time')


csv_header=$( IFS=$';'; echo "${timestamp_array[*]}" )
sed_patterns=$( IFS=$'|'; echo "${timestamp_array[*]}" )

# write header row
echo $csv_header > $output_file


$gwtmstmp_bin -p $po -g |

   # create virtual record seperator
   sed 's/User:/###User:/g' |

   # remove all linebreaks
   tr -d '\n' |

   # replace virtual seperator with linebreak
   sed 's/###/\n/g' |

   # remove extra white spaces (multiple white spaces in a row)
   sed 's/^ *//g' | sed 's/$ *//g' | sed 's/   */ /g' |

   # replace patterns with a common separator
   sed -r "s/$sed_patterns/#/g" |

   # remove first separator
   sed -r 's/^#: //g' |

   # remove extra whitespace around separator
   sed -r 's/ #: /;/g' |

   # strip empty lines
   grep -v '^$' |

   # output desired fields
   cut -d\; -f1,"${timestamp_index[*]}"  >> $output_file


exit 0
