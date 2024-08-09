const std = @import("std");
const cli = @import("cli/cli.zig");
const Lexer = @import("token/token.zig").Lexer;
const Token = @import("token/token.zig").Token;
const TokenType = @import("token/token.zig").TokenType;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = cli.Args.init();
    try cli.initCli(&args, allocator);
    var lexer = Lexer.init(args.file_content.?);

    while (true) {
        const token = lexer.tokenizer();
        if (token.type == TokenType.CONSTANT and token.lexeme.len == 0) {
            break;
        }

        std.debug.print("Token: {s}, Lexeme: {s}\n", .{tokenToString(token.type), token.lexeme});
    }
}

fn tokenToString(tokenType: TokenType) []const u8 {
    return switch (tokenType) {
        .INT_LIT => "INT_LIT",
        .VOID => "VOID",
        .RETURN => "RETURN",
        .IDENTIFIER => "IDENTIFIER",
        .CONSTANT => "CONSTANT",
        .OPEN_BRACES => "OPEN_BRACES",
        .CLOSE_BRACES => "CLOSE_BRACES",
        .OPEN_PARENTHESIS => "OPEN_PARENTHESIS",
        .CLOSE_PARENTHESIS => "CLOSE_PARENTHESIS",
        .SEMICOLON => "SEMICOLON"
    };
}
