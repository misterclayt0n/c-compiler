const std = @import("std");
const Token = @import("../token/token.zig").Token;
const TokenType = @import("../token/token.zig").TokenType;
const tokenToString = @import("../token/token.zig").tokenToString;

pub const Parser = struct {
    tokens: []Token,
    pos: usize,

    pub fn init(tokens: []Token) Parser {
        return Parser{
            .tokens = tokens,
            .pos = 0,
        };
    }

    fn takeToken(self: *Parser) !Token {
        if (self.pos >= self.tokens.len) {
            return error.UnexpectedEndOfInput;
        }
        const token = self.tokens[self.pos];
        self.pos += 1;
        return token;
    }

    fn expect(self: *Parser, expected: TokenType) !Token {
        const token = try self.takeToken();
        if (token.type != expected) {
            std.debug.print("Syntax error: expected {s}, found {s}\n", .{tokenToString(expected), tokenToString(token.type)});
            return error.SyntaxError;
        }

        return token;
    }

    pub fn parseProgram(self: *Parser) !Program {
        const function = try self.parseFunction();
        return Program{
            .function = function,
        };
    }

    fn parseFunction(self: *Parser) !Function {
        _ = try self.expect(.INT_LIT); // expect "int"
        const name_token = try self.expect(.IDENTIFIER); // expect the name of the function
        const name = name_token.lexeme; // agora podemos acessar lexeme de name_token
        _ = try self.expect(.OPEN_PARENTHESIS); // wait "("
        _ = try self.expect(.VOID); // wait "void"
        _ = try self.expect(.CLOSE_PARENTHESIS); // wait ")"
        _ = try self.expect(.OPEN_BRACES); // expect "{"
        const body = try self.parseStatement(); // process function body
        _ = try self.expect(.CLOSE_BRACES); // expect "}"
        return Function{
            .name = name,
            .body = body,
        };
    }

    fn parseStatement(self: *Parser) !Statement {
        _ = try self.expect(.RETURN); // expect "return"
        const constant = try self.parseExp(); // process expression
        _ = try self.expect(.SEMICOLON); // end of expression (;)
        return Statement{
            .Return = constant,
        };
    }

    fn parseExp(self: *Parser) !Constant {
        const token = try self.expect(.CONSTANT);
        const tokenLexeme = token.lexeme;
        const value = std.fmt.parseInt(i32, tokenLexeme, 10) catch {
            return error.ExpectedConstantInteger;
        };

        return Constant{
            .value = value,
        };
    }
};

pub fn printProgram(program: Program) void {
    std.debug.print("Program(\n", .{});
    printFunction(program.function);
    std.debug.print(")\n", .{});
}

fn printFunction(function: Function) void {
    std.debug.print("  Function(\n", .{});
    std.debug.print("    name=\"{s}\"\n", .{function.name});
    printStatement(function.body);
    std.debug.print("  )\n", .{});
}

fn printStatement(statement: Statement) void {
    std.debug.print("    Return(\n", .{});
    printConstant(statement.Return);
    std.debug.print("    )\n", .{});
}

fn printConstant(constant: Constant) void {
    std.debug.print("      Constant({d})\n", .{constant.value});
}

const Program = struct {
    function: Function,
};

const Function = struct {
    name: []const u8,
    body: Statement,
};

const Statement = struct {
    Return: Constant,
};

const Constant = struct {
    value: i32,
};
