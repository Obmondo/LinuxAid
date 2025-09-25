# @summary Class for managing the Obmondo system monitoring
#
class monitor::system (
) {
  lookup('monitor::system::defaults').each | $service | {
      contain $service
  }
}
