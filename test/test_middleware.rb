require 'helper'

class TestMiddleware < Minitest::Test
  def setup
    @middleware = Raisin::Middleware.new(->(env) { :ok })
  end

  def test_not_vendored_header
    assert_equal :ok, @middleware.call({})
  end

  def test_wrong_vendor_header
    env = {}

    assert_equal :ok, @middleware.call(env)
    assert_empty env
  end

  def test_vendored_header
    env = {
      'action_dispatch.request.parameters' => {},
      'HTTP_ACCEPT' => 'application/vnd.acme.v1+json'
    }

    assert_equal :ok, @middleware.call(env)
    assert_equal 'v1', env['raisin.version']
    refute_empty env['action_dispatch.request.formats']
  end
end
