require 'helper'

class GlobalLocatorTest < ActiveSupport::TestCase
  setup do
    model = Person.new('id')
    @gid  = model.gid
    @sgid = model.sgid
  end

  test 'by GID' do
    found = GlobalID::Locator.locate(@gid)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by SGID' do
    found = GlobalID::Locator.locate_signed(@sgid)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by GID string' do
    found = GlobalID::Locator.locate(@gid.to_s)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by SGID string' do
    found = GlobalID::Locator.locate_signed(@sgid.to_s)
    assert_kind_of @sgid.model_class, found
    assert_equal @sgid.model_id, found.id
  end

  test 'by to_param encoding' do
    found = GlobalID::Locator.locate(@gid.to_param)
    assert_kind_of @gid.model_class, found
    assert_equal @gid.model_id, found.id
  end

  test 'by non-GID returns nil' do
    assert_nil GlobalID::Locator.locate 'This is not a GID'
  end

  test 'by non-SGID returns nil' do
    assert_nil GlobalID::Locator.locate_signed 'This is not a SGID'
  end

  test 'by invalid GID URI returns nil' do
    assert_nil GlobalID::Locator.locate 'http://app/Person/1'
    assert_nil GlobalID::Locator.locate 'gid://Person/1'
    assert_nil GlobalID::Locator.locate 'gid://app/Person'
    assert_nil GlobalID::Locator.locate 'gid://app/Person/1/2'
  end
end
