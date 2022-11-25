module OBSWS
  module Version
    module_function

    def major
      0
    end

    def minor
      1
    end

    def patch
      2
    end

    def to_a
      [major, minor, patch]
    end

    def to_s
      to_a.join(".")
    end
  end
end
