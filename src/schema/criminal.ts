import mongoose from 'mongoose';
import { parseDOB, parseSex, parseDDate } from '../lib/helpers';

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

const criminalSchema = new mongoose.Schema({
    fullname: { type: String, required: true, text: true },
    surname: { type: String, required: true, index: true },
    name: { type: String, required: true, index: true },
    patronymic: { type: String, required: true, index: true },
    dob: {
        type: String,
        required: true,
        index: true,
        set(value: string) {
            return parseDOB(value);
        },
    },
    sex: {
        type: String,
        required: true,
        index: true,
        set(value: string) {
            return parseSex(value);
        },
    },
    ddate: {
        type: String,
        set(value: string) {
            return parseDDate(value);
        },
    },
    dplace: { type: String, required: true },
    deterrence: { type: String, required: true },
    article: { type: String, required: true },
    contact: { type: String, required: true },
    photo: { type: String },
    url: { type: String, required: true, unique: true },
});

export default mongoose.model<ICriminal>('Criminal', criminalSchema);
