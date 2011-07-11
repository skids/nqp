role QRegex::Cursor {
    has str $!target;
    has int $!from;
    has int $!pos;
    has $!match;
    has $!bstack;

    method target() { $!target }
    method from() { $!from }
    method pos() { $!pos }

    method MATCH() {
        my $mclass := self.match_class();
        $!match := nqp::create($mclass);
        nqp::bindattr($!match, $mclass, '$!target', $!target);
        nqp::bindattr_i($!match, $mclass, '$!from', $!from);
        nqp::bindattr_i($!match, $mclass, '$!to', $!pos);
        $!match;
    }

    method !cursor_init($target, :$p = 0) {
        my $new := self.CREATE();
        $target := pir::trans_encoding__Ssi($target, pir::find_encoding__Is('ucs4'));
        nqp::bindattr_s($new, $?CLASS, '$!target', $target);
        nqp::bindattr_i($new, $?CLASS, '$!from', $p);
        nqp::bindattr_i($new, $?CLASS, '$!pos', $p);
        $new;
    }

    method !cursor_start() {
        my $new := self.CREATE();
        nqp::bindattr($new, $?CLASS, '$!pos', $!pos);
        pir::return__vPsiPP(
            $new, 
            nqp::bindattr_s($new, $?CLASS, '$!target', $!target),
            nqp::bindattr_i($new, $?CLASS, '$!from', $!pos),
            $?CLASS,
            nqp::bindattr_i($new, $?CLASS, '$!bstack', pir::new__Ps('ResizableIntegerArray'))
        )
    }

    method !cursor_pass($pos) {
        $!match := 1;
        $!pos := $pos;
    }

    method !cursor_fail() {
        $!match  := nqp::null();
        $!bstack := nqp::null();
        $!pos    := -3;
    }

}

class NQPMatch is NQPCapture {
    has $!target;
    has int $!from;
    has int $!to;
    has $!ast;
    has $!cursor;

    method Bool() is parrot_vtable('get_bool') { $!to >= $!from }
}

class NQPCursor does QRegex::Cursor {
    method match_class() { NQPMatch }
}

