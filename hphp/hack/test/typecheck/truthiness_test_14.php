<?hh // strict

function test(bool $b, string $s): void {
  $x = $b ? $s : $b;
  if ($x) {
  }
}
