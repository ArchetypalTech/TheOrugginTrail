import { AnyRouter, ProcedureType } from '@trpc/server';
import { HTTPBatchLinkOptions } from '../HTTPBatchLinkOptions';
import { CancelFn, Operation, TRPCClientRuntime, TRPCLink } from '../types';
import { HTTPResult, ResolvedHTTPLinkOptions } from './httpUtils';
/**
 * @internal
 */
export type RequesterFn<TOptions extends HTTPBatchLinkOptions> = (requesterOpts: ResolvedHTTPLinkOptions & {
    runtime: TRPCClientRuntime;
    type: ProcedureType;
    opts: TOptions;
}) => (batchOps: Operation[], unitResolver: (index: number, value: NonNullable<HTTPResult>) => void) => {
    promise: Promise<HTTPResult[]>;
    cancel: CancelFn;
};
/**
 * @internal
 */
export declare function createHTTPBatchLink<TOptions extends HTTPBatchLinkOptions>(requester: RequesterFn<TOptions>): <TRouter extends AnyRouter>(opts: TOptions) => TRPCLink<TRouter>;
//# sourceMappingURL=createHTTPBatchLink.d.ts.map