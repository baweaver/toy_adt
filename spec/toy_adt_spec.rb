# typed: false
# frozen_string_literal: true

Coord = ToyAdt.type(x: Integer, y: Integer, z: Integer) do
  def translate(x: 0, y: 0, z: 0)
    self.class.new(x: @x + x, y: @y + y, z: @z + z)
  end
end

Shape = ToyAdt.sum(
  circle: { radius: Integer, center: Coord },
  square: { top_left: Coord, bottom_right: Coord }
) do
  def translate(x: 0, y: 0, z: 0)
    case self
    when self::Circle
      self::Circle.new(radius:, center: center.translate(x:, y:, z:))
    when self::Square
      self::Square.new(
        top_left: top_left.translate(x:, y:, z:),
        bottom_right: bottom_right.translate(x:, y:, z:)
      )
    else
      T.absurd(self)
    end
  end
end

RSpec.describe ToyAdt do
  it "has a version number" do
    expect(ToyAdt::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  describe "Public API" do
    let(:center) { Coord.new(x: 0, y: 0, z: 0) }

    describe ".type" do
      it "allows you to create a quick typed struct" do
        expect(Coord).to be_a(Class)
      end

      it "will work with valid data" do
        expect(center).to be_a(Coord)
      end

      it "will fail when given invalid data" do
        expect {
          Coord.new(x: 0, y: 0, z: "INVALID")
        }.to raise_exception(
          TypeError,
          /Parameter 'z': Can't set Coord\.z to "INVALID"/
        )
      end

      it "will allow methods to be defined" do
        expect(center.translate(z: 10).z).to eq(10)
      end
    end

    describe ".sum" do
      let(:circle) { Shape::Circle.new(radius: 5, center: center) }
      let(:square) do
        Shape::Square.new(
          top_left: center,
          bottom_right: center.translate(x: -10, y: -10)
        )
      end

      it "can create a sum class" do
        expect(Shape).to be_a(Module)
      end

      it "can create both sub-types" do
        expect(circle).to be_a(Shape::Circle)
        expect(square).to be_a(Shape::Square)
      end

      it "can be used in keyword pattern matching" do
        result =
          case circle
          in Shape::Circle[radius: 10] then false
          in Shape::Circle[radius: 5] then true
          in Shape::Square then false
          end

        expect(result).to eq(true)
      end
    end
  end
end
