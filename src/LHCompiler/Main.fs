// For emacs: -*- fsharp -*-

module Main

open System
open System.IO
open Argu
open LHCompiler

type CliArguments =
    | Input of path:string * dataExpr:string
    | Core of path:string
    | Message of path:string * id:string * expr:string
    | AsmOnly
    | Version
    | Debug

    interface IArgParserTemplate with
        member s.Usage =
            match s with
            | Input _ -> "Compile a full Ackix program together with its initial state."
            | Core _ -> "Compile Ackix Core program into assembly."
            | Message _ -> "Generate message for a Ackix actor."
            | AsmOnly -> "Produce assembly file and stop."
            | Debug -> "Output all available information during the compilation process (debugging mode)."
            | Version -> "Print compiler version and quit."


let printVersion () =
    printfn "Ackix (Ackixhouse) Compiler Ver.0.0.1 "

[<EntryPoint>]
let main argv =
    let errorHandler =
        ProcessExiter (colorizer =
                        function
                           | ErrorCode.HelpText -> None
                           | _ -> Some ConsoleColor.Red )
    let parser = ArgumentParser.Create<CliArguments>(programName = "lc",
                                                     errorHandler = errorHandler)
    try
        let results = parser.ParseCommandLine argv
        let debug = results.Contains Debug
        let asmOnly = results.Contains AsmOnly
        let isFift = false
        if results.Contains Version then
            printVersion () |> ignore
            1
        elif results.Contains Input then
            let (path, dataExpr) = results.GetResult Input
            LHCompiler.compileFile debug asmOnly isFift path dataExpr |> ignore
            0
        elif results.Contains Core then
            let path = results.GetResult Core
            let progText = File.ReadAllText(path)
            LHCompiler.compile progText  false debug isFift
            |> (fun s ->
                use output = System.IO.File.CreateText(path + ".asm")
                if isFift then fprintf output "\"Asm.fif\" include\n <{ \n %s \n }>s runvmcode .s" s
                else fprintf output "%s" s) |> ignore
            0
        elif results.Contains Message then
            let (path, id, expr) = results.GetResult Message
            LHCompiler.compileMessage path id expr
            0
        else
            printfn "%s" (parser.PrintUsage()) |> ignore
            1
    with
    | CompilerError s ->
        printfn "Compiler error: %s" s
        1
    | e ->
        printfn "Error: %s" e.Message
        printfn "Source: %s" e.Source
        1
        // printfn "Stack trace: %s..." e.StackTrace
