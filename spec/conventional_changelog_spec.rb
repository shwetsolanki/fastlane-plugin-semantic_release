require 'spec_helper'

describe Fastlane::Actions::ConventionalChangelogAction do
  describe "Conventional Changelog" do
    before do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::RELEASE_NEXT_VERSION] = '1.0.2'
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::RELEASE_ANALYZED] = true
    end

    def execute_lane_test
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog end").runner.execute(:test)
    end

    def execute_lane_test_plain
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'plain' ) end").runner.execute(:test)
    end

    def execute_lane_test_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack' ) end").runner.execute(:test)
    end

    def execute_lane_test_author
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_author: true ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header_plain
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'plain', display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack', display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_links
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_links: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_links_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack', display_links: false ) end").runner.execute(:test)
    end

    describe 'section creation' do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]

      it 'should generate sections in markdown format' do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - sub ([short_hash](/long_hash))\n \n ### Documentation\n - sub ([short_hash](/long_hash))"

        expect(execute_lane_test).to eq(result)
      end

      it "should create sections in plain format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "1.0.2 () (2019-05-25)\n \n Bug fixes:\n - sub (/long_hash)\n \n Documentation:\n - sub (/long_hash)"

        expect(execute_lane_test_plain).to eq(result)
      end

      it "should create sections in Slack format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*1.0.2 () (2019-05-25)*\n \n *Bug fixes*\n - sub (</long_hash|short_hash>)\n \n *Documentation*\n - sub (</long_hash|short_hash>)"

        expect(execute_lane_test_slack).to eq(result)
      end
    end

    describe 'hiding headers if display_title is false' do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]

      it "should hide in markdown format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "### Bug fixes\n - sub ([short_hash](/long_hash))\n \n ### BREAKING CHANGES\n - Test ([short_hash](/long_hash))"

        expect(execute_lane_test_no_header).to eq(result)
      end

      it "should hide in plain format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "Bug fixes:\n - sub (/long_hash)\n \n BREAKING CHANGES:\n - Test (/long_hash)"

        expect(execute_lane_test_no_header_plain).to eq(result)
      end

      it "should hide in slack format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*Bug fixes*\n - sub (</long_hash|short_hash>)\n \n *BREAKING CHANGES*\n - Test (</long_hash|short_hash>)"

        expect(execute_lane_test_no_header_slack).to eq(result)
      end
    end

    describe 'showing the author if display_author is true' do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]

      it "should display in markdown format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - sub ([short_hash](/long_hash)) - Jiri Otahal\n \n ### BREAKING CHANGES\n - Test ([short_hash](/long_hash)) - Jiri Otahal"

        expect(execute_lane_test_author).to eq(result)
      end
    end

    describe 'displaying a breaking change' do
      it "should display in markdown format" do
        commits = [
          "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
        ]
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - sub ([short_hash](/long_hash))\n \n ### BREAKING CHANGES\n - Test ([short_hash](/long_hash))"

        expect(execute_lane_test).to eq(result)
      end

      it "should display in slack format" do
        commits = [
          "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
        ]
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*1.0.2 () (2019-05-25)*\n \n *Bug fixes*\n - sub (</long_hash|short_hash>)\n \n *BREAKING CHANGES*\n - Test (</long_hash|short_hash>)"

        expect(execute_lane_test_slack).to eq(result)
      end
    end

    describe 'displaying scopes' do
      commits = [
        "fix(test): sub||long_hash|short_hash|Jiri Otahal|time"
      ]

      it "should display in markdown format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - **test:** sub ([short_hash](/long_hash))"

        expect(execute_lane_test).to eq(result)
      end

      it "should display in slack format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*1.0.2 () (2019-05-25)*\n \n *Bug fixes*\n - *test:* sub (</long_hash|short_hash>)"

        expect(execute_lane_test_slack).to eq(result)
      end
    end

    describe 'skipping merge conflicts' do
      commits = [
        "Merge ...||long_hash|short_hash|Jiri Otahal|time",
        "Custom Merge...||long_hash|short_hash|Jiri Otahal|time",
        "fix(test): sub||long_hash|short_hash|Jiri Otahal|time"
      ]

      it "should skip in markdown format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - **test:** sub ([short_hash](/long_hash))\n \n ### Other work\n - Custom Merge... ([short_hash](/long_hash))"

        expect(execute_lane_test).to eq(result)
      end

      it "should skip in slack format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*1.0.2 () (2019-05-25)*\n \n *Bug fixes*\n - *test:* sub (</long_hash|short_hash>)\n \n *Other work*\n - Custom Merge... (</long_hash|short_hash>)"

        expect(execute_lane_test_slack).to eq(result)
      end
    end

    describe 'hiding links if display_links is false' do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]

      it "should hide in markdown format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "# 1.0.2 () (2019-05-25)\n \n ### Bug fixes\n - sub\n \n ### Documentation\n - sub"

        expect(execute_lane_test_no_links).to eq(result)
      end

      it "should hide in Slack format" do
        allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
        allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

        result = "*1.0.2 () (2019-05-25)*\n \n *Bug fixes*\n - sub\n \n *Documentation*\n - sub"

        expect(execute_lane_test_no_links_slack).to eq(result)
      end
    end

    after do
    end
  end
end
