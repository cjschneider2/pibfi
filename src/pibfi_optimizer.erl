%%% BEGIN pibfi_optimizer.erl %%%
%%%
%%% pibfi - Platonic Ideal Brainf*ck Interpreter
%%% Copyright (c)2003 Cat's Eye Technologies.  All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions
%%% are met:
%%%
%%%   Redistributions of source code must retain the above copyright
%%%   notice, this list of conditions and the following disclaimer.
%%%
%%%   Redistributions in binary form must reproduce the above copyright
%%%   notice, this list of conditions and the following disclaimer in
%%%   the documentation and/or other materials provided with the
%%%   distribution.
%%%
%%%   Neither the name of Cat's Eye Technologies nor the names of its
%%%   contributors may be used to endorse or promote products derived
%%%   from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
%%% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
%%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
%%% OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
%%% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
%%% OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
%%% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
%%% OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%%% POSSIBILITY OF SUCH DAMAGE. 

%% @doc Optimizer for <code>pibfi</code>.
%%
%% <p>Takes an internal format as generated by the parser and
%% returns a (hopefully) more efficient internal format.</p>
%%
%% @end

-module(pibfi_optimizer).
-vsn('2003.0425').
-copyright('Copyright (c)2003 Cat`s Eye Technologies. All rights reserved.').

-export([optimize/1]).

%% @spec optimize(program()) -> program()
%% @doc Optimizes a Brainf*ck program.

optimize(Program) ->
  list_to_tuple(lists:reverse(optimize(Program, 1, undefined, 0, []))).

optimize(Program, Pos, Current, Count, Acc) when Pos > size(Program) ->
  Acc;
optimize(Program, Pos, Current, Count, Acc) ->
  Element = element(Pos, Program),
  NewElement = case Element of
    {instruction, R0, C0, Current} ->
      Acc0 = [{instruction, R0, C0, {Current, Count + 1}} | tl(Acc)],
      optimize(Program, Pos + 1, Current, Count + 1, Acc0);
    {instruction, R0, C0, Instruction}=I
     when Instruction == $<; Instruction == $>;
          Instruction == $+; Instruction == $- ->
      optimize(Program, Pos + 1, Instruction, 1, [I | Acc]);
    {instruction, R0, C0, Other}=I ->
      optimize(Program, Pos + 1, undefined, 1, [I | Acc]);
    {while, R0, C0, Block} ->
      optimize(Program, Pos + 1, undefined, 1,
       [{while, R0, C0, optimize(Block)} | Acc])
  end.

%%% END of pibfi_optimizer.erl %%%
