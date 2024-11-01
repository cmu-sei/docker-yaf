def test_yaf_version(host):
    version = "2.16.1"
    command = """PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/netsa/lib/pkgconfig \
                 pkg-config --modversion libyaf"""

    cmd = host.run(command)

    assert version in cmd.stdout
