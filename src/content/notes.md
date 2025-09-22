# Notes

## Content Length

We don't need to [set the content-length](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ntent-Length):

> In HTTP/2, Content-Length is redundant, because the
> content length may be inferred from DATA frames. It
> may still be included for backwards compatibility.

We do it anyway for backwards compatibility. We set it
based on the output content which is normalized to
bytes. The `content-length` is the length in bytes, not
the length of string.

