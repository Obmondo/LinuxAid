# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions' do
  context 'base valid required data' do
    let(:data) do
      [
        {
          name: 'test_action',
          type: 'omfile'
        }
      ]
    end

    it { is_expected.to allow_value(data) }
  end

  context 'action parameters' do
    context 'single valid value' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            action_params: {
              'action.writeallmarkmessages' => 'on'
            }
          }
        ]
      end

      it { is_expected.to allow_value(data) }
    end

    context 'multiple valid values' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            action_params: {
              'action.writeallmarkmessages' => 'on',
              'action.errorfile' => '/var/log/rsyslog/errors',
              'action.resumeinterval' => 20
            }
          }
        ]
      end

      it { is_expected.to allow_value(data) }
    end

    context 'invalid value' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            action_params: ['test']
          }
        ]
      end

      it { is_expected.not_to allow_value(data) }
    end
  end

  context 'queue parameters' do
    context 'single valid value' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            queue_params: {
              'queue.filename' => 'queue_file'
            }
          }
        ]
      end

      it { is_expected.to allow_value(data) }
    end

    context 'multiple valid values' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            queue_params: {
              'queue.filename' => 'queue_file',
              'queue.spoolDirectory' => '/var/run/rsyslog/spool',
              'queue.type' => 'LinkedList'
            }
          }
        ]
      end

      it { is_expected.to allow_value(data) }
    end

    context 'invalid value' do
      let(:data) do
        [
          {
            name: 'test_action',
            type: 'omfile',
            queue_params: {
              'queue.type' => 'file'
            }
          }
        ]
      end

      it { is_expected.not_to allow_value(data) }
    end
  end

  context 'output parameters' do
    context 'omamqp1' do
      context 'valid required values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omamqp1',
              output_params: {
                host: 'localhost',
                target: 'remotehost'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omelasticsearch' do
      context 'valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omelasticsearch',
              output_params: {
                server: 'elasticsearch1',
                serverport: 9200,
                healthchecktimeout: 3500,
                searchindex: 'system',
                dynsearchindex: 'off',
                searchtype: 'events',
                dynsearchtype: 'off',
                pipelinename: 'test',
                dynpipelinename: 'off',
                usehttps: 'on',
                timeout: '1m',
                template: 't_es_json',
                bulkmode: 'on',
                parent: 'parent_id',
                dynparent: 'off',
                uid: 'elasticsearch',
                pwd: 'password',
                errorfile: '/var/log/elasticsearch/error',
                'tls.cacert' => '/etc/elasticsearch/certs/ca.pem',
                'tls.mycert' => '/etc/elasticsearch/certs/cert.pem',
                'tls.myprivkey' => '/etc/elasticsearch/certs/key.pem',
                bulkid: 'bulk_id',
                dynbulkid: 'off',
                writeoperation: 'create',
                retryfailures: 'off',
                retryruleset: 'r_elasticsearch',
                'ratelimit.interval' => 600,
                'ratelimit.burst' => 20_000
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omfile' do
      context 'valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omfile',
              output_params: {
                file: '/var/log/test.log',
                template: 't_logging',
                closetimeout: 120,
                dynafilecachesize: 10,
                ziplevel: 1,
                veryrobustzip: 'on',
                flushinterval: 100,
                asyncwriting: 'off',
                flushontxend: 'on',
                iobuffersize: '10M',
                dirowner: 'root',
                dirgroup: 'root',
                fileowner: 'rsyslog',
                filegroup: 'rsyslog',
                filecreatemode: '0644',
                dircreatemode: '0755'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omfwd' do
      context 'valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omfwd',
              output_params: {
                target: 'server',
                port: 1234,
                protocol: 'tcp',
                networknamespace: 'foo',
                address: '192.168.1.1',
                ipfreebind: 0,
                device: 'eth0',
                tcp_framing: 'traditional',
                tcp_framedelimiter: 44,
                ziplevel: 5,
                'compression.mode' => 'stream:always',
                'compression.stream.flushontxend' => 'off',
                rebindinterval: 300,
                keepalive: 'on',
                'keepalive.probes' => 2,
                'keepalive.interval' => 30,
                'keepalive.time' => 300,
                streamdriver: 'tcp',
                streamdrivermode: 0,
                streamdriverauthmode: 'baz',
                streamdriverpermittedpeers: 'next',
                resendlastmsgonreconnect: 'off',
                'udp.sendtoall' => 'off',
                gnutlsprioritystring: 'high'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omhiredis' do
      context 'valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omhiredis',
              output_params: {
                server: 'localhost',
                serverport: 1234,
                serverpassword: 'password',
                mode: 'queue',
                template: 't_redis_template',
                key: 'key1',
                userpush: 'off'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omhttpfs' do
      context 'valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omhttpfs',
              output_params: {
                host: 'localhost',
                port: 1234,
                user: 'username',
                https: 'on',
                file: 'test',
                isdynfile: 'off',
                template: 't_httpfs'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omjournal' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omjournal',
              output_params: {
                template: 't_journal'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omkafka' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omkafka',
              output_params: {
                broker: 'foo',
                topic: 'bar',
                key: 'baz',
                dynatopic: 'off',
                'dynatopic.cachesize' => 30,
                'partitions.auto' => 'off',
                'partitions.number' => 10,
                'partitions.usefixed' => 0,
                errorfile: 'error_file',
                confparam: ['test=yes', 'test2=no'],
                topicconfparam: %w[topic1 topic2],
                template: 't_kafka',
                closetimeout: 30,
                resubmitonfailure: 'off',
                keepfailedmessages: 'off',
                failedmsgfile: 'msg_file'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omlibdbi' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omlibdbi',
              output_params: {
                driver: 'firebird',
                server: 'localhost',
                uid: 'user',
                pwd: 'password',
                db: 'database1',
                template: 't_libdbi_firebird'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'ommail' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'ommail',
              output_params: {
                server: 'mail.localhost',
                port: 25,
                mailfrom: 'user1@example.com',
                mailto: 'user2@example.com',
                'subject.template' => 't_subject',
                'subject.text' => 'Test Subject',
                'body.enable' => 'on',
                template: 't_mail'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'ommongodb' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'ommongodb',
              output_params: {
                uristr: 'mongodb://vulture:9091,vulture2:9091/?replicaset=Vulture&ssl=true',
                ssl_cert: '/tmp/cert/cert.pem',
                ssl_ca: '/tmp/cert/ca.pem',
                db: 'foo',
                collection: 'syslog',
                allowed_error_codes: %w[11000 47],
                template: 't_mongo'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'ommysql' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'ommysql',
              output_params: {
                server: 'mysql.example.com',
                socket: '/var/lib/mysql.sock',
                db: 'database1',
                uid: 'user',
                pwd: 'password',
                'mysqlconfig.file' => '/etc/mysql/my.cnf',
                'mysqlconfig.section' => 'foo',
                template: 't_mysql'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'ompgsql' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'ompgsql',
              output_params: {
                server: 'postgres.example.com',
                port: 2009,
                db: 'database1',
                user: 'user',
                pass: 'password',
                template: 't_postgres'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'ompipe' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'ompipe',
              output_params: {
                pipe: 'pipe'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omprog' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omprog',
              output_params: {
                template: 't_program',
                binary: '/usr/local/bin/prog',
                confirmmessages: 'off',
                reportfailures: 'on',
                usetransactions: 'off',
                output: '/var/log/rsyslog/program_log',
                filecreatemode: '0600',
                'hup.signal' => 'HUP',
                signalonclose: 'on',
                closetimeout: 1000,
                killunresponsive: 'on',
                forcesingleinstance: 'off'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omrelp' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omrelp',
              output_params: {
                target: 'localhost',
                template: 't_relp',
                timeout: 600,
                'conn.timeout' => 1200,
                rebindinterval: 30,
                windowsize: 64,
                tls: 'off',
                localclientip: '192.168.100.2'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omsnmp' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omsnmp',
              output_params: {
                server: 'snmp.example.com',
                port: 161,
                transport: 'udp',
                version: 1,
                community: 'public',
                trapoid: '1.3.6.1.4.1.19406.1.2.1',
                messageoid: '1.3.6.1.4.1.19406.1.2.1',
                enterpriseoid: '1.3.6.1.4.1.3.1.1',
                specifictype: 0,
                traptype: 0
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omudpspoof' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omudpspoof',
              output_params: {
                target: 'localhost',
                port: 514,
                sourcetemplate: 't_foo',
                'sourceport.start' => 32_000,
                'sourceport.end' => 33_000,
                mtu: 1500,
                template: 't_udpspoof'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omusrmsg' do
      context 'has valid values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omusrmsg',
              output_params: {
                users: '*',
                template: 't_usr_msg'
              }
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end

    context 'omuxsock' do
      context 'has no values' do
        let(:data) do
          [
            {
              name: 'test_action',
              type: 'omuxsock'
            }
          ]
        end

        it { is_expected.to allow_value(data) }
      end
    end
  end
end
