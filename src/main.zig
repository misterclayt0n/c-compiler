const std = @import("std");
const stdout = std.io.getStdOut().writer();
const log = std.log;
const yazap = @import("yazap");

const App = yazap.App;
const Arg = yazap.Arg;

const Args = struct {
    file_path: ?[]const u8,
    preprocessed_file: ?[]const u8,
    assembly_file: ?[]const u8,
    output_file: ?[]const u8,

    use_lex_only: bool = false,
    use_parse_only: bool = false,
    use_codegen_only: bool = false,
    use_lex: bool = false,

    pub fn init() Args {
        return Args{
            .file_path = null,
            .preprocessed_file = null,
            .assembly_file = null,
            .output_file = null,
        };
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = Args.init();

    try parseArguments(allocator, &args);

    if (args.file_path == null) {
        std.debug.print("No input file provided\n", .{});
        return;
    }
}

fn parseArguments(allocator: std.mem.Allocator, args: *Args) !void {
    var app = App.init(allocator, "c-compiler", "self explanatory I suppose");
    defer app.deinit();
    var c_compiler = app.rootCommand();
    try c_compiler.addArg(Arg.positional("FILE_NAME", null, null));
    // c_compiler.setProperty(.positional_arg_required);
    try c_compiler.addArg(Arg.booleanOption("lex", 'l', "Directs it to run the lexer, but stop before parsing"));
    try c_compiler.addArg(Arg.booleanOption("parse", 'p', "Directs it to run the lexer and parser, but stop before assembly generation"));
    try c_compiler.addArg(Arg.booleanOption("codegen", 'c', "​Directs it to perform lexing, parsing, and assembly generation, but stop before code emission"));
    try c_compiler.addArg(Arg.booleanOption("assembly", 'S', "Generates assembly from input, without linking it"));
    try c_compiler.addArg(Arg.booleanOption("version", 'v', "Prints the version"));

    const matches = try app.parseProcess();
    args.file_path = "we very gucci";

    if (!matches.containsArgs()) {
        try app.displayHelp();
        return;
    }

    if (matches.containsArg("lex")) {
        std.debug.print("TODO: \nlex", .{});
        return;
    }

    if (matches.containsArg("parse")) {
        std.debug.print("TODO: parse\n", .{});
        return;
    }
    if (matches.containsArg("codegen")) {
        std.debug.print("TODO: codegen\n", .{});
        return;
    }

    if (matches.containsArg("assembly")) {
        std.debug.print("TODO: assembly\n", .{});
        return;
    }

    if (matches.containsArg("version")) {
        std.debug.print("v0.1.0\n", .{});
        return;
    }

    if (matches.getSingleValue("FILE_NAME")) |file_name| {
        try catFile(file_name, allocator);
    }

    return;
}

fn catFile(file_path: []const u8, allocator: std.mem.Allocator) !void {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    const bytes_read = try file.read(buffer);
    if (bytes_read != buffer.len) {
        return error.UnexpectedFileLength;
    }

    try stdout.writeAll(buffer);
}
