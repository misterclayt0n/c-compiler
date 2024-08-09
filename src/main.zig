const std = @import("std");
const cli = @import("cli/cli.zig");
const Lexer = @import("token/token.zig").Lexer;
const Token = @import("token/token.zig").Token;
const TokenType = @import("token/token.zig").TokenType;
const tokenToString = @import("token/token.zig").tokenToString;
const Parser = @import("parser/parser.zig").Parser;
const printProgram = @import("parser/parser.zig").printProgram;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = cli.Args.init();
    try cli.initCli(&args, allocator);

    if (args.file_content == null) {
        return;
    }

    var lexer = Lexer.init(args.file_content.?);
    const tokens = try lexer.tokenizeAll();
    var parser = Parser.init(tokens);
    const program = try parser.parseProgram();

    printProgram(program);
}
