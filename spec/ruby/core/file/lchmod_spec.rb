require_relative '../../spec_helper'

describe "File.lchmod" do
  platform_is_not :linux, :windows, :openbsd, :solaris, :aix do
    before :each do
      @fname = tmp('file_chmod_test')
      @lname = @fname + '.lnk'

      touch(@fname) { |f| f.write "rubinius" }

      rm_r @lname
      File.symlink @fname, @lname
    end

    after :each do
      rm_r @lname, @fname
    end

    it "changes the file mode of the link and not of the file" do
      File.chmod(0222, @lname).should == 1
      File.lchmod(0755, @lname).should == 1

      File.lstat(@lname).executable?.should == true
      File.lstat(@lname).readable?.should == true
      File.lstat(@lname).writable?.should == true

      File.stat(@lname).executable?.should == false
      File.stat(@lname).readable?.should == false
      File.stat(@lname).writable?.should == true
    end
  end

  platform_is :openbsd, :aix do
    it "returns false from #respond_to?" do
      File.respond_to?(:lchmod).should be_false
    end

    it "raises a NotImplementedError when called" do
      -> { File.lchmod 0, "foo" }.should raise_error(NotImplementedError)
    end
  end

  platform_is :linux do
    it "raises a NotImplementedError or Errno::ENOTSUP when called" do
      -> { File.lchmod 0, "foo" }.should raise_error(Exception) { |e|
        [NotImplementedError, Errno::ENOTSUP].should include(e.class)
      }
    end
  end
end
