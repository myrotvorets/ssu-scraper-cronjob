import mongoose from 'mongoose';
import { parseDDate, parseDOB, parseSex } from '../lib/helpers.js';

export interface Criminal {
    fullname: string;
    surname: string;
    name: string;
    patronymic: string;
    dob: string | null;
    sex: string;
    ddate: string | null;
    dplace: string;
    deterrence: string;
    article: string;
    contact: string;
    photo: string | null;
    url: string;
}

export interface ICriminal extends mongoose.Document, Criminal {}

const criminalSchema = new mongoose.Schema(
    {
        fullname: { type: String, text: true },
        surname: { type: String, index: true },
        name: { type: String, index: true },
        patronymic: { type: String, index: true },
        dob: {
            type: String,
            index: true,
            set(value: string): string | null {
                return parseDOB(value);
            },
        },
        sex: {
            type: String,
            required: true,
            index: true,
            set(value: string): string {
                return parseSex(value);
            },
        },
        ddate: {
            type: String,
            set(value: string): string | null {
                return parseDDate(value);
            },
        },
        dplace: { type: String },
        deterrence: { type: String },
        article: { type: String },
        contact: { type: String },
        photo: { type: String },
        url: { type: String, unique: true },
    },
    {
        versionKey: false,
        skipVersioning: {
            dontVersionMe: true,
        },
    },
);

export default mongoose.model<ICriminal>('Criminal', criminalSchema, 'new_criminals');
