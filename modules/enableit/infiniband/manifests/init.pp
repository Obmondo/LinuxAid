# This class knows how to setup mellanox infiniband on CentOS
class infiniband {
  kmod::autoload { 'infiniband': modules => ['mlx4_en','mlx4_ib', 'ib_ipoib', 'ib_umad'] }
}
