# @summary Installs obmondo-offsite-upload, which copies a backup to S3
#
# Shared by the backups that copy offsite (common::backup::gitea,
# profile::mail::mailcow). Each makes and checks its own local backup and
# hands the files to /opt/obmondo/bin/obmondo-offsite-upload, which uploads
# them as a set with SHA256SUMS and a .complete marker, keeps the newest N
# sets and writes node_exporter metrics (offsite_backup_*{job="..."}).
#
# aws-cli runs from a pinned container, so the host needs no package for it.
#
# @param aws_image The aws-cli container image the upload runs in.
#
# @groups image aws_image
#
class common::backup::offsite_upload (
  String[1] $aws_image = 'docker.io/amazon/aws-cli:2.27.50',
) {
  file { '/opt/obmondo/bin/obmondo-offsite-upload':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('common/backup/offsite-upload.sh.epp', {
      aws_image => $aws_image,
    }),
  }
}
