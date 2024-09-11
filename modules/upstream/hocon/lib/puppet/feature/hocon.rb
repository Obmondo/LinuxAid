require 'puppet/util/feature'

libs = ['hocon',
        'hocon/config_factory',
        'hocon/config_value_factory',
        'hocon/parser/config_document_factory']

Puppet.features.add(:hocon, libs: libs)
