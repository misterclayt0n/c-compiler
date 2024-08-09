const std = @import("std");

pub const TokenType = enum {
    INT_LIT,
    VOID,
    RETURN,
    IDENTIFIER,
    CONSTANT,
    OPEN_PARENTHESIS,
    CLOSE_PARENTHESIS,
    OPEN_BRACES,
    CLOSE_BRACES,
    SEMICOLON,
};

fn identifyKeywordOrIdentifier(lexeme: []const u8) TokenType {
    if (std.mem.eql(u8, lexeme, "int")) return TokenType.INT_LIT;
    if (std.mem.eql(u8, lexeme, "void")) return TokenType.VOID;
    if (std.mem.eql(u8, lexeme, "return")) return TokenType.RETURN;
    return TokenType.IDENTIFIER;
}

pub const Token = struct {
    type: TokenType,
    lexeme: []const u8,
};

pub const Lexer = struct {
    input: []const u8,
    pos: usize,

    pub fn init(input: []const u8) Lexer {
        return Lexer{
            .input = input,
            .pos = 0,
        };
    }

    pub fn tokenizer(self: *Lexer) Token {
        // fuck whitespaces
        while (self.pos < self.input.len and std.ascii.isWhitespace(self.input[self.pos])) {
            self.pos += 1;
        }

        if (self.pos >= self.input.len) {
            return Token{ .type = TokenType.CONSTANT, .lexeme = "" };
        }

        const start = self.pos;

        // handle keywords and identifiers
        if (std.ascii.isAlphabetic(self.input[self.pos])) {
            self.pos += 1;
            while (self.pos < self.input.len and (std.ascii.isAlphanumeric(self.input[self.pos]) or self.input[self.pos] == '_')) {
                self.pos += 1;
            }

            const lexeme = self.input[start..self.pos];
            return Token{
                .type = identifyKeywordOrIdentifier(lexeme),
                .lexeme = lexeme,
            };
        }

        // handle numbers ma man
        if (std.ascii.isDigit(self.input[self.pos])) {
            self.pos += 1;
            while (self.pos < self.input.len and std.ascii.isDigit(self.input[self.pos])) {
                self.pos += 1;
            }

            const lexeme = self.input[start..self.pos];
            return Token{
                .type = TokenType.CONSTANT,
                .lexeme = lexeme,
            };
        }

        // handle single-character tokens
        const single_char_tokens = switch (self.input[self.pos]) {
            '(' => TokenType.OPEN_PARENTHESIS,
            ')' => TokenType.CLOSE_PARENTHESIS,
            '{' => TokenType.OPEN_BRACES,
            '}' => TokenType.CLOSE_BRACES,
            ';' => TokenType.SEMICOLON,
            else => TokenType.CONSTANT,
        };

        self.pos += 1;
        return Token{
            .type = single_char_tokens,
            .lexeme = self.input[start..self.pos],
        };
    }

    pub fn tokenizeAll(self: *Lexer) ![]Token {
        var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
        while (self.pos < self.input.len) {
            const token = self.tokenizer();
            if (token.type == TokenType.CONSTANT and token.lexeme.len == 0) {
                break;
            }

            try tokens.append(token);
        }

        return tokens.toOwnedSlice();
    }
};


pub fn tokenToString(tokenType: TokenType) []const u8 {
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
