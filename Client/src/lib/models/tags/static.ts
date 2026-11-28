export type ContentVisibility = 'Private' | 'Public' | 'Profile';
export const VALID_CONTENT_VISIBILITY: ContentVisibility[] = ['Private', 'Public', 'Profile'];

export type ContentLicense = 'CCBY' | 'CCBYSA' | 'CCBYNC' | 'CCBYNCSA' | 'CCBYND' | 'CCBYNCND' | 'CC0';
export const VALID_CONTENT_LICENSE: ContentLicense[] = ['CCBY', 'CCBYSA', 'CCBYNC', 'CCBYNCSA', 'CCBYND', 'CCBYNCND', 'CC0'];