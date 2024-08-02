*** Settings ***
Documentation       Network Interfaces

Resource            ${CURDIR}${/}..${/}..${/}..${/}..${/}resources/import.resource

Test Timeout        120s


*** Variables ***
${CMD}      ${CENTREON_PLUGINS}
...         --plugin=os::linux::snmp::plugin
...         --mode=memory
...         --hostname=127.0.0.1
...         --snmp-port=2024

*** Test Cases ***
Memory ${tc}
    [Tags]    os    linux    snmp
    ${command}    Catenate
    ...    ${CMD}
    ...    --snmp-community=os/linux/snmp/${walk}
    ...    ${extra_options}

    ${output}    Run    ${command}
    ${output}    Strip String    ${output}
    Should Be Equal As Strings
    ...    ${output}
    ...    ${expected_result}
    ...    Wrong result output for command:${\n}${command}${\n}${\n}Expected output:${\n}${expected_result}${\n}${\n}Obtained output:${\n}${output}${\n}${\n}
    ...    values=False

    Examples:        tc    walk                    extra_options                expected_result    --
            ...      1     memory_huge             --force-32bits-counters      OK: Ram Total: 1.91 TB Used (-buffers/cache): 1.67 TB (87.74%) Free: 239.21 GB (12.26%), Buffer: 694.54 MB, Cached: 219.41 GB, Shared: 9.31 GB | 'used'=1838319321088B;;;0;2095170973696 'free'=256851652608B;;;0;2095170973696 'used_prct'=87.74%;;;0;100 'buffer'=728276992B;;;0; 'cached'=235591376896B;;;0; 'shared'=9997410304B;;;0;
            ...      2     memory_small            --force-32bits-counters      OK: Ram Total: 1.92 GB Used (-buffers/cache): 610.18 MB (31.02%) Free: 1.33 GB (68.98%), Buffer: 30.20 MB, Cached: 433.99 MB, Shared: 22.46 MB | 'used'=639823872B;;;0;2062598144 'free'=1422774272B;;;0;2062598144 'used_prct'=31.02%;;;0;100 'buffer'=31662080B;;;0; 'cached'=455073792B;;;0; 'shared'=23552000B;;;0;
            ...      3     memory_huge_CHEAT       ${EMPTY}                     OK: Ram Total: 5.91 TB Used (-buffers/cache): 5.67 TB (96.04%) Free: 239.21 GB (3.96%), Buffer: 694.54 MB, Cached: 219.41 GB, Shared: 9.31 GB | 'used'=6236365832192B;;;0;6493217484800 'free'=256851652608B;;;0;6493217484800 'used_prct'=96.04%;;;0;100 'buffer'=728276992B;;;0; 'cached'=235591376896B;;;0; 'shared'=9997410304B;;;0;
            ...      4     memory_huge_CHEAT       --warning-usage-prct=90      WARNING: Ram Total: 5.91 TB Used (-buffers/cache): 5.67 TB (96.04%) Free: 239.21 GB (3.96%) | 'used'=6236365832192B;;;0;6493217484800 'free'=256851652608B;;;0;6493217484800 'used_prct'=96.04%;0:90;;0;100 'buffer'=728276992B;;;0; 'cached'=235591376896B;;;0; 'shared'=9997410304B;;;0;
            ...      5     memory_huge_CHEAT       --critical-usage-prct=90     CRITICAL: Ram Total: 5.91 TB Used (-buffers/cache): 5.67 TB (96.04%) Free: 239.21 GB (3.96%) | 'used'=6236365832192B;;;0;6493217484800 'free'=256851652608B;;;0;6493217484800 'used_prct'=96.04%;;0:90;0;100 'buffer'=728276992B;;;0; 'cached'=235591376896B;;;0; 'shared'=9997410304B;;;0;
