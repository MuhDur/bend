# a parameter a kind reads is specialized, and its root goes out at one
# opaque constant; when a kind is stuck on a match of it, the root splits
# it at each constructor, its fields fresh constants, and again inside
# them, until the kind is a literal. At the one constant, q1(f) was stuck,
# so run3 was out of scope (#1175); a match in the body splits it too
# (run4, whose kind ignores f). A branch may rely on its kind (dup
# copies x only where A is Data), so each root keeps the value it read.
# The laws check the values in the emitted book
import Base

type Box is Type:
  Mk{fn: Nat -> Nat}

def q1(f: Box) -> Quant:
  match f:
    case Mk{g}: &1

def run3(f: Box, -A: Kind(q1(f)), +x: Nat) -> Nat:
  match f:
    case Mk{g}:
      match x:
        case 0n: g(x)
        case 1n+p: g(p)

def q0(f: Box) -> Quant:
  &1

def run4(f: Box, -A: Kind(q0(f)), +x: Nat) -> Nat:
  match f:
    case Mk{g}: g(x)

type Mode is Data:
  Shared{}
  Owned{}

type Cfg is Data:
  Cfg{len: Nat, mode: Mode}

def elem_q(c: Cfg) -> Quant:
  match c:
    case Cfg{n, Shared{}}: &2
    case Cfg{n, Owned{}}: &1

def dup(c: Cfg, -A: Kind(elem_q(c)), x: A, d: A) -> (A & A):
  match c:
    case Cfg{n, Shared{}}:
      +y = x
      (y, y)
    case Cfg{n, Owned{}}:
      (x, d)

def pick(p: Nat & Nat) -> Nat:
  match p:
    case (a, b): Nat.add(a, b)

def main() -> Nat:
  Nat.add(Nat.add(run3(Mk{(y: Nat) => 1n}, Nat, 0n), run4(Mk{(y: Nat) => 2n}, Nat, 0n)),
    pick(dup(Cfg{3n, Shared{}}, Nat, 4n, 9n)))

law main_is_11:
  {main() == 11n : Nat}

def main_is_11():
  {==}

#|11n
