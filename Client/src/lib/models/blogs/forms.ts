import type { ContentLicense, ContentVisibility } from "../tags";

export interface BlogCreate {
    readonly title: string;
    readonly body: string;
}

export interface BlogUpdate {
    readonly title: string;
    readonly body: string;
    readonly nsfw: boolean;
    readonly license: ContentLicense;
    readonly visibility: ContentVisibility;
    readonly publishedOn?: Date;
}