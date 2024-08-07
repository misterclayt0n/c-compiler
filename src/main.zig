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

    std.debug.print("file_path: {any}\n", .{args.file_path});
}

fn parseArguments(allocator: std.mem.Allocator, args: *Args) !void {
    var app = App.init(allocator, "c-compiler", "self explanatory I suppose");
    defer app.deinit();
    var c_compiler = app.rootCommand();
    try c_compiler.addArg(Arg.booleanOption("sexo", 's', "no"));
    const matches = try app.parseProcess();
    args.file_path = "we very gucci";

    if (!matches.containsArgs()) {
        try app.displayHelp();
        return;
    }

    if (matches.containsArg("sexo")) {
        log.info("we gucci boyz", .{});
        return;
    }

    return;
}
