const std = @import("std");
const Program = @import("../parser/parser.zig").Program;

const Operand = union(enum) {
    ImmediateValue: i32, // constant immediate value
    Register, // EAX in this case
};

const Instruction = union(enum) {
    Move: struct {
        src: Operand,
        dst: Operand,
    },
    Ret, // just return man
};

const AssemblyFunction = struct {
    name: []const u8,
    instructions: []Instruction,
};

const AssemblyProgram = struct {
    function: AssemblyFunction,
};

pub fn printAssemblyProgram(program: AssemblyProgram) void {
    std.debug.print("{s}:\n", .{program.function.name});
    for (program.function.instructions) |instruction| {
        printInstruction(instruction);
    }
}

fn printInstruction(instruction: Instruction) void {
    switch (instruction) {
        .Move => |mov| {
            std.debug.print("   mov ", .{});
            printOperand(mov.src);
            std.debug.print(", ", .{});
            printOperand(mov.dst);
            std.debug.print("\n", .{});
        },
        .Ret => {
            std.debug.print("   ret\n", .{});
        },
    }
}

fn printOperand(operand: Operand) void {
    switch (operand) {
        .ImmediateValue => |imm| {
            std.debug.print("{d}", .{imm});
        },
        .Register => {
            std.debug.print("eax", .{});
        },
    }
}

pub fn generateAssembly(program: Program) !AssemblyProgram {
    var instructions = std.ArrayList(Instruction).init(std.heap.page_allocator);

    // process function
    const func = program.function;

    // generate MOV to return value
    const mov_instr = Instruction{
        .Move = .{
            .src = Operand{ .ImmediateValue = func.body.Return.value },
            .dst = Operand{ .Register = {} },
        },
    };

    try instructions.append(mov_instr);
    try instructions.append(Instruction{ .Ret = {} });

    return AssemblyProgram{
        .function = AssemblyFunction{
            .name = func.name,
            .instructions = try instructions.toOwnedSlice(),
        },
    };
}
