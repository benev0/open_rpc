/// basically a Result type, but both variants have symmetric value an properties
pub type Either(a, b) {
  Left(a)
  Right(b)
}

pub fn then_left(
  either: Either(a, b),
  apply: fn(a) -> Either(c, b),
) -> Either(c, b) {
  case either {
    Left(left) -> apply(left)
    Right(right) -> Right(right)
  }
}

pub fn then_right(
  either: Either(a, b),
  apply: fn(b) -> Either(a, c),
) -> Either(a, c) {
  case either {
    Right(right) -> apply(right)
    Left(left) -> Left(left)
  }
}

pub fn map_left(either: Either(a, b), apply: fn(a) -> c) -> Either(c, b) {
  case either {
    Left(left) -> Left(apply(left))
    Right(right) -> Right(right)
  }
}

pub fn map_right(either: Either(a, b), apply: fn(b) -> c) -> Either(a, c) {
  case either {
    Right(right) -> Right(apply(right))
    Left(left) -> Left(left)
  }
}

pub fn unwrap_both(either: Either(a, a)) -> a {
  case either {
    Left(left) -> left
    Right(right) -> right
  }
}
