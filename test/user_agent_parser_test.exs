defmodule UserAgentParserTest do
  use ExUnit.Case
  doctest UserAgentParser

  @ua_mac_chrome "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36
"
  @ua_iphone "Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13A342 Safari/601.1"
  @ua_lumia "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; Microsoft; Lumia 640 XL)"
  @ua_windows_chrome "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.5.2171.95 Safari/537.36"
  @ua_windows_firefox "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1"

  test "browser detection" do
    assert UserAgentParser.detect_browser(@ua_mac_chrome) == %UA.Browser{family: "Chrome", version: "49.0.2623"}
    assert UserAgentParser.detect_browser(@ua_iphone) == %UA.Browser{family: "Mobile Safari", version: "9.0"}
    assert UserAgentParser.detect_browser(@ua_lumia) == %UA.Browser{family: "IE Mobile", version: "10.0"}
    assert UserAgentParser.detect_browser(@ua_windows_chrome) == %UA.Browser{family: "Chrome", version: "39.5.2171"}
    assert UserAgentParser.detect_browser(@ua_windows_firefox) == %UA.Browser{family: "Firefox", version: "40.1"}
  end

  test "OS detection" do
    assert UserAgentParser.detect_os(@ua_mac_chrome) == %UA.OS{family: "Mac OS X", version: "10.9.5"}
    assert UserAgentParser.detect_os(@ua_iphone) == %UA.OS{family: "iOS", version: "9.0"}
    assert UserAgentParser.detect_os(@ua_lumia) == %UA.OS{family: "Windows Phone", version: "8.0"}
    assert UserAgentParser.detect_os(@ua_windows_chrome) == %UA.OS{family: "Windows 7", version: nil}
    assert UserAgentParser.detect_os(@ua_windows_firefox) == %UA.OS{family: "Windows 7", version: nil}
  end

  test "device detection" do
    assert UserAgentParser.detect_device(@ua_mac_chrome) == :unknown
    assert UserAgentParser.detect_device(@ua_iphone) == %UA.Device{brand: "Apple", model: "iPhone", name: "iPhone"}
    assert UserAgentParser.detect_device(@ua_lumia) == %UA.Device{brand: "Microsoft", model: "Lumia 640 XL",
 name: "Microsoft Lumia 640 XL"}
  end
end
