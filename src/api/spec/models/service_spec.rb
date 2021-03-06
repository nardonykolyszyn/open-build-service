require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Service, vcr: true do
  let(:user) { create(:confirmed_user, :with_home, login: 'tom') }
  let(:home_project) { user.home_project }
  let(:package) { create(:package, name: 'test_package', project: home_project) }
  let(:service) { package.services }
  let(:url) { "#{CONFIG['source_url']}/source/#{home_project.name}/#{package.name}" }

  context '#addKiwiImport' do
    before do
      login(user)
      service.addKiwiImport
    end

    it 'posts runservice' do
      expect(a_request(:post, "#{url}?cmd=runservice&user=#{user}")).to have_been_made.once
    end

    it 'posts mergeservice' do
      skip('broken because KiwiImport service expects a tar archive, we should move this in Package#save_file.')
      expect(a_request(:post, "#{url}?cmd=mergeservice&user=#{user}")).to have_been_made.once
    end

    it 'posts waitservice' do
      expect(a_request(:post, "#{url}?cmd=waitservice")).to have_been_made.once
    end

    it 'has a kiwi_import service' do
      expect(service.document.xpath("/services/service[@name='kiwi_import']")).not_to be_empty
    end
  end
end
