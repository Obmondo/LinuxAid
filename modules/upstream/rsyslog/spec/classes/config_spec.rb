# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Config', include_rsyslog: true do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it { is_expected.to contain_class('rsyslog::config') }

      classes = %w[modules global legacy main_queue templates actions inputs custom lookup_tables parsers rulesets property_filters expression_filters]
      classes.each do |clas|
        it { is_expected.to contain_class("rsyslog::config::#{clas}") }
      end

      context 'cyclic dependency check' do
        let(:pre_condition) { 'include rsyslog' }
        let(:params) do
          {
            modules: {
              imuxsock: {},
              imudp: {
                config: {
                  threads: '2',
                  TimeRequery: '8',
                  batchSize: '128'
                }
              }
            },
            global_config: {
              umask: {
                value: '0000',
                type: 'legacy',
                priority: 1
              },
              workDirectory: {
                value: '/var/spool/rsyslog'
              },
              maxMessageSize: {
                value: '64k'
              }
            },
            legacy_config: {
              auth_priv_rule: {
                key: 'auth,authpriv.*',
                value: '/var/log/auth.log'
              },
              mail_error_rule: {
                key: 'mail.err',
                value: '/var/log/mail.err'
              }
            },
            main_queue_opts: {
              'queue.maxdiskspace' => '1000G',
              'queue.dequeuebatchsize' => '1000'
            },
            templates: {
              remote: {
                type: 'string',
                string: '/var/log/rsyslog/logs/%fromhost-ip%/%fromhost-ip%.log'
              },
              tpl2: {
                type: 'subtree',
                subtree: '$1!$usr'
              },
              someplug: {
                type: 'plugin',
                plugin: 'foobar'
              }
            },
            actions: {
              'myaction' => {
                type: 'omelasticsearch',
                config: {
                  'queue.type' => 'linkedlist',
                  'queue.spoolDirectory' => '/var/log/rsyslog/queue'
                }
              },
              'myaction2' => {
                type: 'omfile',
                facility: 'kern.*',
                config: {
                  'dynaFile' => 'remoteKern'
                }
              }
            },
            inputs: {
              imudp: {
                type: 'imudp',
                config: {
                  port: '514'
                }
              },
              imptcp: {
                type: 'imptcp',
                config: {
                  port: '514',
                  address: '127.0.0.1'
                }
              }
            },
            lookup_tables: {
              ip_lookup: {
                lookup_json: {
                  version: 1,
                  nolookup: 'unk',
                  type: 'string',
                  table: [
                    {
                      index: '1.1.1.1',
                      value: 'AB'
                    },
                    {
                      index: '2.2.2.2',
                      value: 'CD'
                    }
                  ]
                },
                lookup_file: '/etc/rsyslog.d/tables/ip_lookup.json',
                reload_on_hup: true
              },
              string_lookup: {
                lookup_json: {
                  version: 1,
                  nolookup: 'unk',
                  type: 'string',
                  table: [
                    {
                      index: 'localhost',
                      value: 'ABC'
                    }
                  ]
                },
                lookup_file: '/etc/rsyslog.d/tables/string_lookup.json',
                reload_on_hup: true
              }
            },
            parsers: {
              pmrfc3164_hostname_with_slashes: {
                type: 'pmrfc3164',
                config: {
                  'permit.slashesinhostname' => 'on'
                }
              },
              custom_pmnull: {
                type: 'pmnull',
                config: {
                  tag: 'foo'
                }
              }
            },
            rulesets: {
              eth0_514_tcp: {
                parameters: {
                  parser: 'pmrfc3164',
                  'queue.size' => '10000'
                },
                rules: [
                  { set: { '$!rcv_time' => 'exec_template("s_rcv_time")' } },
                  { set: { '$.utime_gen' => 'exec_template("s_unixtime_generated")' } },
                  { set: { uuid: '$uuid' } },
                  {
                    action: {
                      name: 'utf8-fix',
                      type: 'mmutf8fix'
                    }
                  }
                ],
                stop: true
              },
              eth0_514_udp: {
                parameters: {
                  'queue.type' => 'LinkedList'
                },
                rules: [
                  {
                    expression_filter: {
                      filter: {
                        if: {
                          expression: '$fromhost-ip == "192.168.255.1"',
                          tasks: [
                            { call: 'ruleset.client.log.standard' },
                            { stop: true }
                          ]
                        }
                      }
                    }
                  },
                  { call: 'ruleset.unknown.standard' }
                ],
                stop: true
              }
            },
            property_filters: {
              hostname_filter: {
                property: 'hostname',
                operator: 'contains',
                value: 'some_hostname',
                tasks: [
                  {
                    action: {
                      name: 'omfile_defaults',
                      type: 'omfile',
                      facility: '*.*;auth,authpriv.none',
                      config: {
                        dynaFile: 'remoteSyslog',
                        specifics: '/var/log/test'
                      }
                    }
                  },
                  { stop: true }
                ]
              },
              ip_filter: {
                property: 'fromhost-ip',
                operator: 'startswith',
                value: '192',
                tasks: [
                  { stop: true }
                ]
              }
            },
            expression_filters: {
              hostname_filter: {
                conditionals: {
                  if: {
                    expression: '$msg contains "error"',
                    tasks: [
                      {
                        action: {
                          name: 'omfile_error',
                          type: 'omfile',
                          config: {
                            specifics: '/var/log/errlog'
                          }
                        }
                      }
                    ]
                  }
                }
              },
              complex_filter: {
                conditionals: {
                  if: {
                    expression: '$syslogfacility-text == "local0" and $msg startswith "DEVNAME" and ($msg contains "error1" or $msg contains "error0")',
                    tasks: [
                      { stop: true }
                    ]
                  },
                  else: {
                    tasks: [
                      {
                        action: {
                          name: 'error_log',
                          type: 'omfile',
                          config: {
                            specifics: '/var/log/errlog'
                          }
                        }
                      }
                    ]
                  }
                }
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
