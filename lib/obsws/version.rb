module OBSWS
  module Version
    module_function

    def major
      0
    end

    def minor
      4
    end

    def patch
      1
    end

    def to_a
      [major, minor, patch]
    end

    def to_s
      to_a.join(".")
    end
  end

  VERSION = Version.to_s
end
