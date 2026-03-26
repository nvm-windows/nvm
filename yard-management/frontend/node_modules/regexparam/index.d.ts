export function parse(route: string, loose?: boolean): {
	keys: string[];
	pattern: RegExp;
}

export function parse(route: RegExp): {
	keys: false;
	pattern: RegExp;
}

export type RouteParams<T extends string> =
	T extends `${infer Prev}/*/${infer Rest}`
		? RouteParams<Prev> & { wild: string } & RouteParams<Rest>
	: T extends `${string}:${infer P}?/${infer Rest}`
		? { [K in P]?: string } & RouteParams<Rest>
	: T extends `${string}:${infer P}/${infer Rest}`
		? { [K in P]: string } & RouteParams<Rest>
	: T extends `${string}:${infer P}?`
		? { [K in P]?: string }
	: T extends `${string}:${infer P}`
		? { [K in P]: string }
	: T extends `${string}*`
		? { "*": string }
	: T extends `${string}*?`
		? { "*"?: string }
	: {};

export function inject<T extends string>(route: T, values: RouteParams<T>): string;
