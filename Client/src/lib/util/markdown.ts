import MarkdownIt from "markdown-it";
import type { MarkdownIt as MarkdownItType, StateInline } from "markdown-it";
import type { Config as PurifyConfig } from "dompurify";
import { anchor } from "@mdit/plugin-anchor";
import { align } from "@mdit/plugin-align";
import { embed, type MarkdownItEmbedOptions } from "@mdit/plugin-embed";
import { fullEmoji } from "@mdit/plugin-emoji";
import { imgLazyload } from "@mdit/plugin-img-lazyload";
import { spoiler } from "@mdit/plugin-spoiler";

function emphasis(md: MarkdownItType) {
    const defaultEmphasis = md.inline.ruler.__rules__.find(r => r.name === 'emphasis')?.fn;

    if (defaultEmphasis) {
        md.inline.ruler.at('emphasis', (state: StateInline, silent: boolean) => {
            if (state.src.charCodeAt(state.pos) === 0x5f /* _ */) return false;
            return defaultEmphasis(state, silent);
        });
    }

    md.inline.ruler.before('emphasis', 'single_underscore_underline', (state: StateInline, silent: boolean) => {
        const start = state.pos;
        const src = state.src;

        // must start with a single `_` and not `__`
        if (src.charCodeAt(start) !== 0x5f || src.charCodeAt(start + 1) === 0x5f) {
            return false;
        }

        // cannot be whitespace between `_` and the word
        const afterOpen = src.charCodeAt(start + 1);
        if (Number.isNaN(afterOpen) || md.utils.isWhiteSpace(afterOpen)) {
            return false;
        }

        // Search for a single closing `_` not preceded by whitespace or `\`, and not `__`
        let searchPos = start + 1;
        let closeIndex = -1;

        while (searchPos < src.length) {
            const ch = src.charCodeAt(searchPos);

            if (ch === 0x5c /* \ */) {
                searchPos += 2;
                continue;
            }

            if (ch === 0x5f && src.charCodeAt(searchPos + 1) !== 0x5f) {
                const beforeClose = src.charCodeAt(searchPos - 1);
                if (!md.utils.isWhiteSpace(beforeClose)) {
                    closeIndex = searchPos;
                    break;
                }
            }

            searchPos += 1;
        }

        if (closeIndex === -1 || closeIndex === start + 1) {
            return false;
        }

        if (!silent) {
            const tokenOpen = state.push('underline_open', 'u', 1);
            tokenOpen.markup = '_';

            const oldPos = state.pos;
            const oldPosMax = state.posMax;
            state.pos = start + 1;
            state.posMax = closeIndex;
            state.md.inline.tokenize(state);
            state.pos = oldPos;
            state.posMax = oldPosMax;

            const tokenClose = state.push('underline_close', 'u', -1);
            tokenClose.markup = '_';
        }

        state.pos = closeIndex + 1;
        return true;
    });
}

const embedConfig: MarkdownItEmbedOptions = {
    config: [
        {
            name: "youtube",
            setup: (params: string) => {
                const url = params.trim();
                const match = url.match(/(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/);

                if (match && match[1]) {
                    const videoID = match[1];
                    return `<iframe width="560" height="315" src="https://www.youtube.com/embed/${videoID}" frameborder="0" allowfullscreen></iframe>`;
                }

                return `<a href="${url}">${url}</a>`
            }
        }
    ]
}

export const md = new MarkdownIt({
    html: false,
    linkify: true,
    typographer: true,
    breaks: true,
}).use(emphasis).use(spoiler).use(anchor).use(align).use(fullEmoji).use(imgLazyload).use(embed, embedConfig);

export const purifyConfig: PurifyConfig = {
    ADD_TAGS: ['u', 'span', 'iframe', 'img'],
    ADD_ATTR: [
        'class',
        'tabindex',
        'target',
        'rel',
        'data-unfurl-url',
        'src',
        'alt',
        'title',
        'loading',
        'allow',
        'referrerpolicy',
        'allowfullscreen'
    ]
};