module OBSWS
  module Version
    module_function

    def major
      0
    end

    def minor
      2
    end

    def patch
      0
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
