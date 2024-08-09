const std = @import("std");
const yazap = @import("yazap");
const log = std.log;
const stdout = std.io.getStdOut().writer();

const App = yazap.App;
const Arg = yazap.Arg;

pub const Args = struct {
    file_path: ?[]const u8,
    file_content: ?[]const u8,
    preprocessed_file: ?[]const u8,
    assembly_file: ?[]const u8,
    output_file: ?[]const u8,
    max_file_size: usize,

    use_lex_only: bool = false,
    use_parse_only: bool = false,
    use_codegen_only: bool = false,
    use_lex: bool = false,

    pub fn init() Args {
        return Args{
            .file_path = null,
            .file_content = null,
            .preprocessed_file = null,
            .assembly_file = null,
            .output_file = null,
            .max_file_size = 100000,
        };
    }
};

pub fn initCli(args: *Args, allocator: std.mem.Allocator) !void {
    try parseArguments(allocator, args);

    if (args.file_path == null) {
        return;
    }
}

fn parseArguments(allocator: std.mem.Allocator, args: *Args) !void {
    var app = App.init(allocator, "c-compiler", "self explanatory I suppose");
    defer app.deinit();
    var c_compiler = app.rootCommand();
    try c_compiler.addArg(Arg.positional("FILE_NAME", null, null));
    try c_compiler.addArg(Arg.booleanOption("lex", 'l', "Directs it to run the lexer, but stop before parsing"));
    try c_compiler.addArg(Arg.booleanOption("parse", 'p', "Directs it to run the lexer and parser, but stop before assembly generation"));
    try c_compiler.addArg(Arg.booleanOption("codegen", 'c', "​Directs it to perform lexing, parsing, and assembly generation, but stop before code emission"));
    try c_compiler.addArg(Arg.booleanOption("assembly", 'S', "Generates assembly from input, without linking it"));
    try c_compiler.addArg(Arg.booleanOption("version", 'v', "Prints the version"));

    const matches = try app.parseProcess();

    if (!matches.containsArgs()) {
        try app.displayHelp();
        return;
    }

    if (matches.containsArg("lex")) {
        std.debug.print("TODO: lex\n", .{});
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
        if (std.ascii.endsWithIgnoreCase(file_name, ".c")) {
            args.file_path = file_name;
            args.file_content = try getFileContent(args, allocator);
        } else {
            std.debug.print("{s} is not a valid C program\n", .{file_name});
        }
    }

    return;
}

fn getFileContent(args: *Args, allocator: std.mem.Allocator) ![]const u8 {
    const file = std.fs.cwd().openFile(args.file_path.?, .{}) catch |err| {
        std.debug.print("Failed to open file: {s}\n", .{args.file_path.?});
        return err;
    };
    defer file.close();

    const contents = file.reader().readAllAlloc(allocator, args.max_file_size) catch |err| {
        std.debug.print("Failed to read file: {s}\n", .{args.file_path.?});
        return err;
    };
    return contents;
}
